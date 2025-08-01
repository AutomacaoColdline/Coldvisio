using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IPreventiveMaintenanceService
    {
        Task<List<PreventiveMaintenance>> GetAllAsync();
    }
}
