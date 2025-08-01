using ColdvisioApi.Application.IService;

namespace ColdvisioApi.Infrastructure.Services
{
    public class HelloWorldService : IHelloWorldService
    {
        public string GetMessage()
        {
            return "Hello World from Service!";
        }
    }
}
