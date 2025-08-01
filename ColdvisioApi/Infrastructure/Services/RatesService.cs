using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class RatesService : IRatesService
    {
        private readonly AppDbContext _context;

        public RatesService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Rate>> GetAllAsync()
        {
            return await _context.Rates.ToListAsync();
        }
    }
}
