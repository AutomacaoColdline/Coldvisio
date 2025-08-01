using ColdvisioApi.Domain.Entities;

namespace ColdvisioApi.Application.IService
{
    public interface IDeviceControllerService
    {
        Task<List<DeviceController>> GetAllAsync();
    }
}
