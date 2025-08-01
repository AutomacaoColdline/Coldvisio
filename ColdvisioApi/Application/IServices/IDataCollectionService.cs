using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IDataCollectionService
    {
        Task<List<DataCollection>> GetAllAsync();
    }
}
