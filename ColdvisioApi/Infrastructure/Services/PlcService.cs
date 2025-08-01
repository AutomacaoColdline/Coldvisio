using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class PlcService : IPlcService
    {
        private readonly AppDbContext _context;

        public PlcService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Plc>> GetAllAsync()
        {
            return await _context.Plcs.ToListAsync();
        }
    }
}
