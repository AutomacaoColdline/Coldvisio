using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class SystemActionHistoryService : ISystemActionHistoryService
    {
        private readonly AppDbContext _context;

        public SystemActionHistoryService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<SystemActionHistory>> GetAllAsync()
        {
            return await _context.SystemActionHistories.ToListAsync();
        }
    }
}
