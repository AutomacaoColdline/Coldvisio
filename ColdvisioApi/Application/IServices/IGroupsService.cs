using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IGroupsService
    {
        Task<List<Group>> GetAllAsync();
    }
}
