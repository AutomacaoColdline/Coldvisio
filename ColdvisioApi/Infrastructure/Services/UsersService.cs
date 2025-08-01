using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class UsersService : IUsersService
    {
        private readonly AppDbContext _context;

        public UsersService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<User>> GetAllAsync()
        {
            return await _context.Users.ToListAsync();
        }
    }
}
