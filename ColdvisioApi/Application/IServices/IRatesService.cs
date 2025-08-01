using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IRatesService
    {
        Task<List<Rate>> GetAllAsync();
    }
}
