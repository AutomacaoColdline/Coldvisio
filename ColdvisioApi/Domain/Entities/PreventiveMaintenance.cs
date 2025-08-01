namespace ColdvisioApi.Domain.Entities
{
    public class PreventiveMaintenance
    {
        public int Id { get; set; } // ← Chave primária
        public string DeviceControllerName { get; set; }
        public int? DeviceControllerAddress { get; set; }
        public DateTime? DataTimestamp { get; set; }
        public bool? Notice { get; set; }
        public bool? Alert { get; set; }
    }
}
