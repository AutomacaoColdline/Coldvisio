using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface ISystemActionHistoryService
    {
        Task<List<SystemActionHistory>> GetAllAsync();
    }
}
