local Package = {
    vendor = "МойОфис",
    description = "Это пример расширения для МойОфис",
    extensionID = "test",
    extensionName = "Тестовое Расширение 1",
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
