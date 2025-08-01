using ColdvisioApi.Infrastructure.Configurations;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Adiciona suporte a controllers e Swagger (modular via SwaggerConfig)
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
ServiceRegistration.ConfigureServices(builder.Services);
SwaggerConfig.ConfigureSwagger(builder.Services);
DatabaseConfig.ConfigureDatabase(builder.Services, builder.Configuration);


var app = builder.Build();

// Middleware do Swagger (somente em desenvolvimento)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Coldvisio API v1");
    });
}


app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
