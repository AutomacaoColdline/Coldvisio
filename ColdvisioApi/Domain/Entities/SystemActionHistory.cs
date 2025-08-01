namespace ColdvisioApi.Domain.Entities
{
    public class SystemActionHistory
    {
        public string EventName { get; set; }
        public string EventType { get; set; }
        public string TagName { get; set; }
        public string Origin { get; set; }
        public string Model { get; set; }
        public DateTime? Timestamp { get; set; }
        public string TagValue { get; set; }
        public string LoggedUser { get; set; }
        public string Message { get; set; }
        public string TriggerValue { get; set; }
        public string Priority { get; set; }
        public string AlarmGroup { get; set; }
        public string Area { get; set; }
        public int? SessionId { get; set; }
        public string AlarmTransitionAlarmTransition { get; set; }
    }
}
