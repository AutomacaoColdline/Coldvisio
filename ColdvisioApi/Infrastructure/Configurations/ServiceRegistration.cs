using ColdvisioApi.Application.IService;
using ColdvisioApi.Infrastructure.Services;
using Microsoft.Extensions.DependencyInjection;

namespace ColdvisioApi.Infrastructure.Configurations
{
    public static class ServiceRegistration
    {
        public static void ConfigureServices(IServiceCollection services)
        {
            services.AddScoped<IHelloWorldService, HelloWorldService>();
            services.AddScoped<IDeviceControllerService, DeviceControllerService>();
            services.AddScoped<IUsersService, UsersService>(); 
            services.AddScoped<IGroupsService, GroupsService>();
            services.AddScoped<IPortsService, PortsService>();
            services.AddScoped<IDataEntryService, DataEntryService>();
            services.AddScoped<IDataCollectionService, DataCollectionService>();
            services.AddScoped<IPlcService, PlcService>();
            services.AddScoped<IPreventiveMaintenanceService, PreventiveMaintenanceService>();
            services.AddScoped<IRatesService, RatesService>();
            services.AddScoped<ISystemActionHistoryService, SystemActionHistoryService>();
        }
    }
}
