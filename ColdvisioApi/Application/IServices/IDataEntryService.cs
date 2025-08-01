using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IDataEntryService
    {
        Task<List<DataEntry>> GetAllAsync();
    }
}
