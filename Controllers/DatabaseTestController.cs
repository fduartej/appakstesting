using Microsoft.AspNetCore.Mvc;
using appakstesting.Models;
using appakstesting.Services;

namespace appakstesting.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class DatabaseTestController : ControllerBase
    {
        private readonly IDatabaseTestService _databaseTestService;
        private readonly ILogger<DatabaseTestController> _logger;

        public DatabaseTestController(IDatabaseTestService databaseTestService, ILogger<DatabaseTestController> logger)
        {
            _databaseTestService = databaseTestService;
            _logger = logger;
        }

        /// <summary>
        /// Tests database connectivity and retrieves current date
        /// </summary>
        /// <param name="request">Database test request containing connection string and optional custom query</param>
        /// <returns>Database test results including connection status and current date</returns>
        /// <response code="200">Database test completed successfully</response>
        /// <response code="400">Invalid request parameters</response>
        /// <response code="500">Internal server error during database test</response>
        [HttpPost("test-connection")]
        [ProducesResponseType(typeof(DatabaseTestResponse), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(500)]
        public async Task<ActionResult<DatabaseTestResponse>> TestDatabaseConnection([FromBody] DatabaseTestRequest request)
        {
            try
            {
                if (request == null)
                {
                    return BadRequest(new DatabaseTestResponse 
                    { 
                        ErrorMessage = "Request body is required",
                        TestTimestamp = DateTime.UtcNow
                    });
                }

                _logger.LogInformation("Testing database connection");
                var result = await _databaseTestService.TestDatabaseConnectionAsync(request);
                
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during database test");
                return StatusCode(500, new DatabaseTestResponse 
                { 
                    ErrorMessage = "Internal server error during database test",
                    TestTimestamp = DateTime.UtcNow
                });
            }
        }

        /// <summary>
        /// Gets a simple health check for the API
        /// </summary>
        /// <returns>API health status</returns>
        [HttpGet("health")]
        [ProducesResponseType(200)]
        public ActionResult<object> HealthCheck()
        {
            return Ok(new 
            { 
                status = "healthy", 
                timestamp = DateTime.UtcNow,
                service = "Database Test API"
            });
        }

        /// <summary>
        /// Gets example connection strings for different SQL Server scenarios
        /// </summary>
        /// <returns>Example connection strings</returns>
        [HttpGet("connection-examples")]
        [ProducesResponseType(200)]
        public ActionResult<object> GetConnectionExamples()
        {
            var examples = new
            {
                OnPremiseSqlServer = new
                {
                    description = "SQL Server on-premise with SQL Authentication",
                    connectionString = "Server=your-server;Database=your-database;User Id=your-username;Password=your-password;TrustServerCertificate=true;"
                },
                OnPremiseWindowsAuth = new
                {
                    description = "SQL Server on-premise with Windows Authentication",
                    connectionString = "Server=your-server;Database=your-database;Integrated Security=true;TrustServerCertificate=true;"
                },
                AzureSqlDatabase = new
                {
                    description = "Azure SQL Database",
                    connectionString = "Server=tcp:your-server.database.windows.net,1433;Database=your-database;User ID=your-username;Password=your-password;Encrypt=true;Connection Timeout=30;"
                },
                AzureSqlManagedInstance = new
                {
                    description = "Azure SQL Managed Instance",
                    connectionString = "Server=tcp:your-instance.database.windows.net,1433;Database=your-database;User ID=your-username;Password=your-password;Encrypt=true;Connection Timeout=30;"
                }
            };

            return Ok(examples);
        }
    }
}
