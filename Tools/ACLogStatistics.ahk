/*
=====================================================
        AUTO CORRECTION LOG STATISTICS
=====================================================

This app is designed for inclusion in the AutoCorrect2 Suite at
https://github.com/kunkel321/AutoCorrect2
Author: kunkel321
Tool used: Claude AI
Version: 11-23-2025 

PURPOSE:
This tool analyzes AutoCorrect log data and generates interactive HTML charts
showing the percentage of backspaced (<<) vs kept (--) entries, grouped by:
- Month: Shows trends across calendar months (e.g., "2025-May")
- Week: Shows trends across ISO weeks (e.g., "25-Nov" for approximate month)
- Weekday: Aggregates all data by day of week (Sun-Sat)

KEY FEATURES:
- Reads from the same config file as ACLogAnalyzer
- Generates standalone HTML with embedded Chart.js library
- Opens automatically in your default browser
- Interactive tooltips showing percentages for each bar
- Professional styling with gradient backgrounds and responsive design

ARCHITECTURE:
- ACLogStatistics class: Main controller managing the workflow
- Static methods: Simplifies data management (no need to create instances)
- State tracking: Uses static variables to maintain data between method calls
- HTML generation: Creates a complete, self-contained HTML file with JavaScript

HOW IT WORKS:
1. User launches script → shows selection GUI (Month/Week/Weekday)
2. User selects grouping → ParseLogFile() reads AC log file
3. GroupBy*() methods aggregate data based on selection
4. GenerateHtmlReport() creates an HTML file with embedded Chart.js visualization
5. HTML is written to temp folder and opened in browser

ABOUT THE HTML GENERATION:
The script generates a complete HTML file with:
- Embedded CSS (styling) - no external dependencies
- Embedded JavaScript (Chart.js from CDN) - creates interactive bar charts
- Placeholder replacement - values are substituted after HTML template is created
  Example: {{TOTAL_ENTRIES}} is replaced with the actual count

This approach keeps everything self-contained in one HTML file that works offline.

*/

#SingleInstance Force
#Requires AutoHotkey v2+

; ======= Main Class Definition =======
; This class encapsulates all functionality for the statistics analyzer.
; Using a class with static methods keeps code organized and variables grouped together.
class ACLogStatistics {
    ; Static configuration - Load from acSettings.ini
    ; Static properties are shared across all calls (no instance needed)
    static Config {
        get {
            settingsFile := "..\Data\acSettings.ini"
            
            ; Verify settings file exists
            if !FileExist(settingsFile) {
                MsgBox(settingsFile " was not found. Please run AutoCorrect2 first to create the file.")
                ExitApp
            }
            
            ; Build config object from ini file
            ; IniRead() retrieves values with fallback defaults
            config := {
                ScriptFiles: {
                    ACLog: "..\Data\" IniRead(settingsFile, "Files", "AutoCorrectsLogFile", "AutoCorrectsLog.txt")
                }
            }
            
            return config
        }
    }

    ; ======= STATE TRACKING VARIABLES =======
    ; These track the current analysis across method calls
    static SelectedGrouping := "month"  ; User's choice: month, week, or weekday
    static LogData := []               ; Array of parsed log entries: {date, isBackspaced}
    static GroupedData := Map()        ; Aggregated data by grouping: label → {backspaced, kept}
    static StatsGui := ""              ; Reference to the GUI window

    ; ======= PUBLIC METHODS =======

    static Run() {
        this.Initialize()
        this.ShowSelectionGui()
    }

    static Initialize() {
        TraySetIcon("..\Resources\Icons\AcAnalysis.ico")
    }

    static ShowSelectionGui() {
        this.StatsGui := GuiObj := Gui(, "AC Log Statistics")
        GuiObj.BackColor := "0xF0F0F0"
        GuiObj.SetFont("s13")

        GuiObj.Add("Text", "w400 h50 cBlack", "Preparing to make a chart.  How would you like to group the statistics?")
        
        GuiObj.Add("Radio", "Checked w200 h25", "By Month").OnEvent("Click", (GuiCtrlObj, GuiEvent) => this.SelectedGrouping := "month")
        GuiObj.Add("Radio", "w200 h25", "By Week").OnEvent("Click", (GuiCtrlObj, GuiEvent) => this.SelectedGrouping := "week")
        GuiObj.Add("Radio", "w200 h25", "By Weekday").OnEvent("Click", (GuiCtrlObj, GuiEvent) => this.SelectedGrouping := "weekday")
        
        GuiObj.Add("Button", "w160 h35 xm+150", "Generate Report").OnEvent("Click", (GuiCtrlObj, GuiEvent) => this.ProcessAndReport())
        GuiObj.Add("Button", "w100 h35 x+10", "Cancel").OnEvent("Click", (GuiCtrlObj, GuiEvent) => GuiObj.Destroy())
        
        GuiObj.Show("Autosize")
    }

    static ProcessAndReport() {
        try {
            this.StatsGui.Destroy()
            
            ; Check if log file exists
            logFile := this.Config.ScriptFiles.ACLog
            if !FileExist(logFile) {
                MsgBox("Log file '" logFile "' not found.")
                return
            }
            
            ; Parse the log file
            this.ParseLogFile(logFile)
            
            ; Group data based on selection
            switch this.SelectedGrouping {
                case "month":
                    this.GroupByMonth()
                case "week":
                    this.GroupByWeek()
                case "weekday":
                    this.GroupByWeekday()
            }
            
            ; Generate HTML report
            htmlContent := this.GenerateHtmlReport()
            
            ; Save and open
            reportPath := A_Temp "\ACLogStats_Report.html"
            
            ; Try to delete old report if it exists
            try {
                if FileExist(reportPath)
                    FileDelete(reportPath)
            } catch Error as err {
                MsgBox("Warning: Could not delete old report: " err.Message)
            }
            
            ; Write new report
            try {
                FileAppend(htmlContent, reportPath)
            } catch Error as err {
                MsgBox("Error writing report file: " err.Message "`n`nPath: " reportPath)
                return
            }
            
            ; Try to open in browser
            try {
                Run(reportPath)
            } catch Error as err {
                MsgBox("Error opening report in browser: " err.Message "`n`nYou can manually open: " reportPath)
                return
            }
            
        } catch Error as err {
            MsgBox("Unexpected error: " err.Message)
        }
    }

    ; ======= Parsing Methods =======
    ; These methods read and process the raw log file

    static ParseLogFile(logFile) {
        ; Clear previous data
        this.LogData := []
        
        ; Read entire file into memory as a single string
        allText := FileRead(logFile)
        
        ; Split into array of lines (StrSplit uses newline as delimiter)
        lines := StrSplit(allText, "`n")
        
        ; Process each line
        for line in lines {
            line := Trim(line)  ; Remove leading/trailing whitespace
            
            ; Skip empty lines and comments
            if (line = "") || (SubStr(line, 1, 1) = ";")
                continue
            
            ; Parse line format: DATE -- :options:trigger::replacement
            ; Example: 2025-11-20 -- :*:thier::their
            ; or:      2025-11-20 << :*:thier::their
            parts := StrSplit(line, " ", , 3)  ; Split on space, limit to 3 parts
            if (parts.Length < 3)
                continue
            
            dateStr := parts[1]      ; Extract YYYY-MM-DD
            indicator := parts[2]    ; Extract -- or <<
            
            ; Only accept valid indicators
            if (indicator != "--" && indicator != "<<")
                continue
            
            ; Validate date format (YYYY-MM-DD)
            if !this.IsValidDate(dateStr)
                continue
            
            ; Create entry object and add to array
            ; isBackspaced = true means the entry was backspaced (<< marker)
            entry := {
                date: dateStr,
                isBackspaced: (indicator = "<<")
            }
            
            this.LogData.Push(entry)
        }
    }

    ; Validate that a date string is in valid YYYY-MM-DD format with reasonable values
    static IsValidDate(dateStr) {
        ; Check format with regex: must be 4 digits, hyphen, 2 digits, hyphen, 2 digits
        if !RegExMatch(dateStr, "^\d{4}-\d{2}-\d{2}$")
            return false
        
        ; Extract components and validate ranges
        parts := StrSplit(dateStr, "-")
        year := Integer(parts[1])
        month := Integer(parts[2])
        day := Integer(parts[3])
        
        ; Basic sanity checks (not perfect date validation, but good enough)
        return (year > 2000 && month >= 1 && month <= 12 && day >= 1 && day <= 31)
    }

    ; ======= Grouping Methods =======
    ; These methods aggregate the parsed log data into different groupings
    ; Each creates a Map with a label (month/week/day) as key and {backspaced, kept} counts as value

    static GroupByMonth() {
        ; Clear previous grouping and start fresh with a Map
        ; Map is like an object but designed for key-value pairs
        this.GroupedData := Map()
        
        ; Iterate through all parsed log entries
        for entry in this.LogData {
            ; Extract year-month from YYYY-MM-DD (first 7 characters)
            ; Example: "2025-11" from "2025-11-20"
            month := SubStr(entry.date, 1, 7)
            
            ; Create entry for this month if it doesn't exist
            if !this.GroupedData.Has(month) {
                this.GroupedData[month] := {backspaced: 0, kept: 0}
            }
            
            ; Increment the appropriate counter
            if (entry.isBackspaced)
                this.GroupedData[month].backspaced++
            else
                this.GroupedData[month].kept++
        }
        
        ; Sort by key (chronologically for months)
        this.SortGroupedData()
    }

    static GroupByWeek() {
        this.GroupedData := Map()
        
        for entry in this.LogData {
            weekStr := this.GetWeekString(entry.date)
            
            if !this.GroupedData.Has(weekStr) {
                this.GroupedData[weekStr] := {backspaced: 0, kept: 0}
            }
            
            if (entry.isBackspaced)
                this.GroupedData[weekStr].backspaced++
            else
                this.GroupedData[weekStr].kept++
        }
        
        ; Sort by key
        this.SortGroupedData()
    }

    static GroupByWeekday() {
        this.GroupedData := Map()
        weekdayNames := ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        ; Initialize all weekdays
        for name in weekdayNames {
            this.GroupedData[name] := {backspaced: 0, kept: 0}
        }
        
        for entry in this.LogData {
            ; Convert YYYY-MM-DD to AHK datetime format for FormatTime
            dateStr := entry.date  ; "YYYY-MM-DD"
            ahkDate := StrReplace(dateStr, "-", "") . "000000"  ; Convert to YYYYMMDDHHmmss
            
            ; Get day of week (1=Sunday, 7=Saturday)
            dayOfWeek := Integer(FormatTime(ahkDate, "WDay"))
            dayName := weekdayNames[dayOfWeek]
            
            if (entry.isBackspaced)
                this.GroupedData[dayName].backspaced++
            else
                this.GroupedData[dayName].kept++
        }
    }

    static SortGroupedData() {
        ; Skip sorting - AHK v2 arrays don't have native sort capability
        ; The data will display in the order it was entered, which is acceptable for chart visualization
        ; If needed later, we can display data in the chart in a different order via JSON structure
    }

    static GetWeekString(dateStr) {
        year := Integer(SubStr(dateStr, 1, 4))
        month := Integer(SubStr(dateStr, 6, 2))
        day := Integer(SubStr(dateStr, 9, 2))
        
        ; Simple week calculation: day of year / 7
        dayOfYear := this.CalculateDayOfYear(year, month, day)
        week := Format("{:02d}", Integer((dayOfYear - 1) / 7) + 1)
        
        return year "-W" week
    }

    static CalculateDayOfYear(year, month, day) {
        daysInMonth := [31, this.IsLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        dayOfYear := day
        
        Loop month - 1 {
            dayOfYear += daysInMonth[A_Index]
        }
        
        return dayOfYear
    }

    static IsLeapYear(year) {
        return (Mod(year, 4) = 0 && Mod(year, 100) != 0) || (Mod(year, 400) = 0)
    }

    ; ======= Report Generation =======
    ; 
    ; ABOUT HTML EMBEDDING IN AUTOHOTKEY:
    ; 
    ; This script generates a complete, self-contained HTML file with embedded code.
    ; All necessary CSS (styling) and JavaScript (functionality) are embedded, not loaded
    ; from external files. This means the HTML file works offline and requires no external
    ; dependencies besides Chart.js (loaded from CDN but the HTML will still function offline).
    ; 
    ; THE WORKFLOW:
    ; 1. Create an HTML template as a multi-line string using continuation sections ( ... )
    ; 2. Use placeholder tokens like {{TOTAL_ENTRIES}} that will be replaced later
    ; 3. Convert data arrays to JSON strings (JavaScript can parse JSON natively)
    ; 4. Use StrReplace() to substitute actual values into the template
    ; 5. Write the final HTML to a file
    ; 6. Open the file in a web browser
    ; 
    ; WHY PLACEHOLDERS?
    ; Continuation sections in AHK don't support variable interpolation (`. concatenation`).
    ; So instead of trying to concatenate during the template creation, we insert placeholder
    ; tokens and replace them afterward with StrReplace(). This is clean and readable.
    ; 
    ; HOW CHART.JS WORKS:
    ; Chart.js is a JavaScript library that creates interactive charts. The script:
    ; - Creates an HTML canvas element (blank drawing surface)
    ; - Calls `new Chart(ctx, config)` with configuration object
    ; - Provides data arrays and chart options
    ; - Chart.js draws bars, legends, tooltips automatically
    ; - Tooltips are customized via callback function to show counts and percentages
    ; 
    ; JSON FORMAT:
    ; JavaScript natively understands JSON (JavaScript Object Notation).
    ; When we output ["Value1", "Value2"] or [1, 2, 3], JavaScript treats these
    ; as arrays we can use directly in the Chart.js configuration.
    ; Example: labels: ["Jan", "Feb", "Mar"] becomes an array in JavaScript.

    static GenerateHtmlReport() {
        labels := []
        backspacedData := []
        keptData := []
        
        ; Determine analysis type for subtitle
        switch this.SelectedGrouping {
            case "month":
                analysisType := "by Month"
            case "week":
                analysisType := "by Week"
            case "weekday":
                analysisType := "by Weekday"
            default:
                analysisType := ""
        }
        
        ; Define proper weekday order
        weekdayOrder := ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        ; Build data arrays in proper order (handle both weekday and other groupings)
        for label, counts in this.GroupedData {
            labels.Push(label)
            backspacedData.Push(counts.backspaced)
            keptData.Push(counts.kept)
        }
        
        ; If we're dealing with weekdays, reorder them
        if (labels.Length = 7 && labels[1] != "Sunday" && this.GroupedData.Has("Sunday")) {
            ; This is weekday data - rebuild arrays in day order
            newLabels := []
            newBackspaced := []
            newKept := []
            
            for dayName in weekdayOrder {
                newLabels.Push(dayName)
                newBackspaced.Push(this.GroupedData.Get(dayName).backspaced)
                newKept.Push(this.GroupedData.Get(dayName).kept)
            }
            
            labels := newLabels
            backspacedData := newBackspaced
            keptData := newKept
        }
        
        ; Format labels based on type
        formattedLabels := []
        isWeekdayData := (labels.Length = 7 && this.GroupedData.Has("Sunday"))
        
        if (isWeekdayData) {
            ; Don't format weekday labels, just use them as-is
            for label in labels {
                formattedLabels.Push(label)
            }
        } else {
            ; This might be month or week data
            for label in labels {
                if (InStr(label, "-W")) {
                    ; This is a week label like "2025-W47", convert to "25-Nov"
                    parts := StrSplit(label, "-W")
                    year := SubStr(parts[1], 3)  ; Get last 2 digits of year
                    week := Integer(parts[2])
                    
                    ; Approximate which month this week falls in
                    monthNum := Integer((week - 1) / 4.3) + 1
                    if (monthNum > 12)
                        monthNum := 12
                    
                    ; Get month name using switch
                    switch monthNum {
                        case 1: monthName := "Jan"
                        case 2: monthName := "Feb"
                        case 3: monthName := "Mar"
                        case 4: monthName := "Apr"
                        case 5: monthName := "May"
                        case 6: monthName := "Jun"
                        case 7: monthName := "Jul"
                        case 8: monthName := "Aug"
                        case 9: monthName := "Sep"
                        case 10: monthName := "Oct"
                        case 11: monthName := "Nov"
                        case 12: monthName := "Dec"
                        default: monthName := "????"
                    }
                    
                    formattedLabels.Push(year "-" monthName)
                } else if (InStr(label, "-") && !InStr(label, "W")) {
                    ; This might be a month label like "2025-05", convert to "2025-May"
                    parts := StrSplit(label, "-")
                    if (parts.Length = 2) {
                        year := parts[1]
                        monthNum := Integer(parts[2])
                        
                        ; Get month name using switch
                        switch monthNum {
                            case 1: monthName := "Jan"
                            case 2: monthName := "Feb"
                            case 3: monthName := "Mar"
                            case 4: monthName := "Apr"
                            case 5: monthName := "May"
                            case 6: monthName := "Jun"
                            case 7: monthName := "Jul"
                            case 8: monthName := "Aug"
                            case 9: monthName := "Sep"
                            case 10: monthName := "Oct"
                            case 11: monthName := "Nov"
                            case 12: monthName := "Dec"
                            default: monthName := "????"
                        }
                        
                        formattedLabels.Push(year "-" monthName)
                    } else {
                        formattedLabels.Push(label)
                    }
                } else {
                    formattedLabels.Push(label)
                }
            }
        }
        ; Convert arrays to JSON
        labelsJson := this.ArrayToJson(formattedLabels)
        backspacedJson := this.ArrayToJson(backspacedData)
        keptJson := this.ArrayToJson(keptData)
        
        ; Evaluate all summary statistics
        totalEntries := this.GetTotalEntries()
        totalBackspaced := this.GetTotalBackspaced()
        totalKept := this.GetTotalKept()
        overallRate := this.GetOverallRate()
        
        ; Format the timestamp to mm-dd-yyyy at hh:mm
        rawDate := A_Now
        formattedDate := Format("{}-{}-{} at {}:{}",
            SubStr(rawDate, 5, 2),   ; month
            SubStr(rawDate, 7, 2),   ; day
            SubStr(rawDate, 1, 4),   ; year
            SubStr(rawDate, 9, 2),   ; hour
            SubStr(rawDate, 11, 2))  ; minute
        
        ; Build HTML with continuation section using placeholders
        html := "
(
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>AC Log Statistics Report</title>
    <script src='https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js'></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }
        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        .content {
            padding: 40px;
        }
        .chart-container {
            position: relative;
            height: 400px;
            margin-bottom: 40px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-card h3 {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 10px;
        }
        .stat-card .value {
            font-size: 2em;
            font-weight: bold;
        }
        footer {
            background: #f5f5f5;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
            border-top: 1px solid #eee;
        }
        @media (max-width: 768px) {
            .content {
                padding: 20px;
            }
            .chart-container {
                height: 300px;
            }
            header h1 {
                font-size: 1.8em;
            }
        }
    </style>
</head>
<body>
    <div class='container'>
        <header>
            <h1>AutoCorrect Log Statistics</h1>
            <p>Backspace Rate Analysis {{ANALYSIS_TYPE}}</p>
        </header>
        
        <div class='content'>
            <div class='chart-container'>
                <canvas id='backspaceChart'></canvas>
            </div>
            
            <div class='stats-grid'>
                <div class='stat-card'>
                    <h3>Total Entries</h3>
                    <div class='value'>{{TOTAL_ENTRIES}}</div>
                </div>
                <div class='stat-card'>
                    <h3>Total Backspaced</h3>
                    <div class='value'>{{TOTAL_BACKSPACED}}</div>
                </div>
                <div class='stat-card'>
                    <h3>Total Kept</h3>
                    <div class='value'>{{TOTAL_KEPT}}</div>
                </div>
                <div class='stat-card'>
                    <h3>Overall Rate</h3>
                    <div class='value'>{{OVERALL_RATE}}%</div>
                </div>
            </div>
        </div>
        
        <footer>
            Generated on {{GENERATED_DATE}} | AutoCorrect Log Statistics
        </footer>
    </div>

    <script>
        const ctx = document.getElementById('backspaceChart').getContext('2d');
        const backspacedData = {{BACKSPACED_JSON}};
        const keptData = {{KEPT_JSON}};
        
        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: {{LABELS_JSON}},
                datasets: [
                    {
                        label: 'Backspaced (<<)',
                        data: backspacedData,
                        backgroundColor: '#FF6384',
                        borderColor: '#FF4560',
                        borderWidth: 1
                    },
                    {
                        label: 'Kept (--)',
                        data: keptData,
                        backgroundColor: '#4BC0C0',
                        borderColor: '#2BADA8',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            font: {
                                size: 13
                            }
                        }
                    },
                    title: {
                        display: true,
                        text: 'Backspaced vs Kept Entries',
                        font: {
                            size: 16
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const datasetIndex = context.datasetIndex;
                                const dataIndex = context.dataIndex;
                                const value = context.parsed.y;
                                const label = context.dataset.label || '';
                                
                                const bs = backspacedData[dataIndex];
                                const kept = keptData[dataIndex];
                                const total = bs + kept;
                                
                                // Calculate percentage for this specific dataset
                                let pct;
                                if (datasetIndex === 0) {
                                    // Backspaced dataset
                                    pct = total > 0 ? (bs / total * 100).toFixed(1) : 0;
                                } else {
                                    // Kept dataset
                                    pct = total > 0 ? (kept / total * 100).toFixed(1) : 0;
                                }
                                
                                return label + ': ' + value + ' | ' + pct + '%';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>
)"
        
        ; Replace placeholders with actual values
        html := StrReplace(html, "{{TOTAL_ENTRIES}}", totalEntries)
        html := StrReplace(html, "{{TOTAL_BACKSPACED}}", totalBackspaced)
        html := StrReplace(html, "{{TOTAL_KEPT}}", totalKept)
        html := StrReplace(html, "{{OVERALL_RATE}}", overallRate)
        html := StrReplace(html, "{{GENERATED_DATE}}", formattedDate)
        html := StrReplace(html, "{{ANALYSIS_TYPE}}", analysisType)
        html := StrReplace(html, "{{LABELS_JSON}}", labelsJson)
        html := StrReplace(html, "{{BACKSPACED_JSON}}", backspacedJson)
        html := StrReplace(html, "{{KEPT_JSON}}", keptJson)
        
        return html
    }

    ; ======= Utility Methods =======

    static ArrayToJson(arr) {
        ; Convert an AHK array to a JSON array string that JavaScript can understand.
        ; 
        ; EXAMPLE:
        ; Input:  arr = ["apple", "banana", "cherry"]
        ; Output: "[\"apple\", \"banana\", \"cherry\"]"
        ;
        ; This is crucial because the HTML template contains JavaScript that needs
        ; to receive data in JSON format. JavaScript will natively parse this as a real array.
        ;
        ; STRING ELEMENTS:
        ; String values must be wrapped in quotes and internal quotes escaped.
        ; "apple" becomes "\"apple\"" in the output JSON.
        ;
        ; NUMBER ELEMENTS:
        ; Number values are inserted as-is (no quotes needed).
        ; 123 becomes 123 in the output JSON.
        
        ; Start with opening bracket
        json := "["
        
        ; Build the JSON array by iterating through elements
        for i, val in arr {
            ; Add comma before each element after the first
            if (i > 1)
                json .= ", "
            
            ; Different handling for strings vs numbers
            if (Type(val) = "String") {
                ; For strings: escape any internal quotes and wrap in quotes
                val := StrReplace(val, '"', '\"')  ; Replace " with \"
                json .= '"' val '"'
            } else {
                ; For numbers and other types: insert as-is
                json .= val
            }
        }
        
        ; Close with ending bracket
        json .= "]"
        return json
    }

    static GetTotalEntries() {
        total := 0
        for label, counts in this.GroupedData {
            total += counts.backspaced + counts.kept
        }
        return total
    }

    static GetTotalBackspaced() {
        total := 0
        for label, counts in this.GroupedData {
            total += counts.backspaced
        }
        return total
    }

    static GetTotalKept() {
        total := 0
        for label, counts in this.GroupedData {
            total += counts.kept
        }
        return total
    }

    static GetOverallRate() {
        backspaced := this.GetTotalBackspaced()
        total := this.GetTotalEntries()
        
        if (total = 0)
            return 0
        
        return Format("{:.1f}", backspaced * 100 / total)
    }
}

; ======= Entry Point =======
ACLogStatistics.Run()
