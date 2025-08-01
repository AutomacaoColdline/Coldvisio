namespace ColdvisioApi.Domain.Entities
{
    public class Plc
    {
        public int Id { get; set; }
        public string DeviceName { get; set; }
        public string Ip { get; set; }
        public string Gateway { get; set; }
        public string SubnetMask { get; set; }
        public int? Status { get; set; }
    }
}
