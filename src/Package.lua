local Package = {
    vendor = "JeKa",
    description = "Это пример расширения для МойОфис",
    extensionID = "report",
    extensionName = "отчет по возможностям",
    extensionVersion = {
        major = 1,
        minor = 1,
        patch = 0,
        build = "mvp1"
    },
    applicationId = "MyOffice Spreadsheet",
    apiVersion = {
        major = 1,
        minor = 0
    },
    fallbackLanguage = 'ru',
    commandsProvider = "cmd/entryform.lua",
}
return Package
