using ColdvisioApi.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ColdvisioApi.Application.IService
{
    public interface IUsersService
    {
        Task<List<User>> GetAllAsync();
    }
}
