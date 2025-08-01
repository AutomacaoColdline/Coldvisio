using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IPlcService
    {
        Task<List<Plc>> GetAllAsync();
    }
}
