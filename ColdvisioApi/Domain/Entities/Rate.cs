namespace ColdvisioApi.Domain.Entities
{
    public class Rate
    {
        public int Id { get; set; }
        public int? DeviceControllerAddress { get; set; }
        public DateTime? Date { get; set; }
        public string DeviceControllerName { get; set; }
        public int? Status { get; set; }
        public int? ComunicacaoOk { get; set; }
        public int? ComunicacaoNok { get; set; }
        public DateTime? Timestamp { get; set; }
    }
}
