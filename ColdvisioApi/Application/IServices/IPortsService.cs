using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IPortsService
    {
        Task<List<Port>> GetAllAsync();
    }
}
