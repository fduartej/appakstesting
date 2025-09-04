using Microsoft.Data.SqlClient;
using appakstesting.Models;
using System.Data;

namespace appakstesting.Services
{
    public interface IDatabaseTestService
    {
        Task<DatabaseTestResponse> TestDatabaseConnectionAsync(DatabaseTestRequest request);
    }

    public class DatabaseTestService : IDatabaseTestService
    {
        private readonly ILogger<DatabaseTestService> _logger;

        public DatabaseTestService(ILogger<DatabaseTestService> logger)
        {
            _logger = logger;
        }

        public async Task<DatabaseTestResponse> TestDatabaseConnectionAsync(DatabaseTestRequest request)
        {
            var response = new DatabaseTestResponse
            {
                TestTimestamp = DateTime.UtcNow,
                IsConnected = false
            };

            try
            {
                if (string.IsNullOrWhiteSpace(request.ConnectionString))
                {
                    response.ErrorMessage = "Connection string is required";
                    return response;
                }

                using var connection = new SqlConnection(request.ConnectionString);
                await connection.OpenAsync();

                response.IsConnected = true;
                response.DatabaseName = connection.Database;
                response.ServerInfo = connection.DataSource;

                // Get current date from database
                using var dateCommand = new SqlCommand("SELECT GETDATE() AS CurrentDate", connection);
                var currentDate = await dateCommand.ExecuteScalarAsync();
                response.CurrentDate = currentDate?.ToString();

                // Execute custom query if provided
                if (!string.IsNullOrWhiteSpace(request.CustomQuery))
                {
                    try
                    {
                        using var customCommand = new SqlCommand(request.CustomQuery, connection);
                        var customResult = await customCommand.ExecuteScalarAsync();
                        response.CustomQueryResult = customResult?.ToString();
                    }
                    catch (Exception customEx)
                    {
                        response.CustomQueryResult = $"Error executing custom query: {customEx.Message}";
                    }
                }

                _logger.LogInformation("Database connection test successful for database: {DatabaseName}", response.DatabaseName);
            }
            catch (SqlException sqlEx)
            {
                _logger.LogError(sqlEx, "SQL Server connection failed");
                response.ErrorMessage = $"SQL Server Error: {sqlEx.Message} (Error Number: {sqlEx.Number})";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Database connection test failed");
                response.ErrorMessage = $"Connection Error: {ex.Message}";
            }

            return response;
        }
    }
}
