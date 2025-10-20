using appakstesting.Services;
using Azure.Identity;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

var builder = WebApplication.CreateBuilder(args);

// Lee el endpoint desde env var (o hardcodea si prefieres)
var appConfigEndpoint = Environment.GetEnvironmentVariable("AzureAppConfigEndpoint")
                        ?? "https://appconfig-noprod-01.azconfig.io";

// Conectar a Azure App Configuration y a Key Vault (referencias)
builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(new Uri(appConfigEndpoint), new DefaultAzureCredential())
           .Select("app:db-testapi:*", labelFilter: "dev")
           .ConfigureKeyVault(kv => kv.SetCredential(new DefaultAzureCredential()));
});


// Add services to the container.
builder.Services.AddControllersWithViews();

// Add API Controllers
builder.Services.AddControllers();

// Add Swagger/OpenAPI services
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo 
    { 
        Title = "Database Test API", 
        Version = "v1",
        Description = "API para probar conectividad a SQL Server (on-premise o Azure SQL)",
        Contact = new Microsoft.OpenApi.Models.OpenApiContact
        {
            Name = "Database Test API",
            Email = "test@example.com"
        }
    });
    
    // Include XML comments if available
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Register services
builder.Services.AddScoped<IDatabaseTestService, DatabaseTestService>();

// Add CORS for API testing
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

app.MapGet("/testconfig", (IConfiguration config) =>
{
    var conn = config["app:db-testapi:ConnectionStrings--DefaultConnection"];
    return Results.Ok(new { ConnectionString = conn ?? "(nulo)" });
});

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

// Enable Swagger in all environments for this testing API
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Database Test API v1");
    c.RoutePrefix = "swagger"; // Swagger UI will be available at /swagger
});

app.UseHttpsRedirection();
app.UseStaticFiles(); // Ensure static files are served
app.UseRouting();

// Enable CORS
app.UseCors("AllowAll");

app.UseAuthorization();

app.MapStaticAssets();

// Map API Controllers
app.MapControllers();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();
