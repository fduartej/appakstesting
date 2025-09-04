namespace appakstesting.Models
{
    public class DatabaseTestRequest
    {
        public string ConnectionString { get; set; } = string.Empty;
        public string? CustomQuery { get; set; }
    }

    public class DatabaseTestResponse
    {
        public bool IsConnected { get; set; }
        public string? CurrentDate { get; set; }
        public string? CustomQueryResult { get; set; }
        public string? ErrorMessage { get; set; }
        public DateTime TestTimestamp { get; set; }
        public string? ServerInfo { get; set; }
        public string? DatabaseName { get; set; }
    }
}
