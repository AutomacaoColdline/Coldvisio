using ColdvisioApi.Application.IService;
using ColdvisioApi.Domain.Entities;
using ColdvisioApi.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace ColdvisioApi.Infrastructure.Services
{
    public class DataEntryService : IDataEntryService
    {
        private readonly AppDbContext _context;

        public DataEntryService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<DataEntry>> GetAllAsync()
        {
            return await _context.DataEntry.ToListAsync();
        }
    }
}
