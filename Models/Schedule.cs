using System.Collections.Generic;

namespace Models
{
    public class Schedule
    {
        public Dictionary<string, Day> schedule { get; set; }
        public Dictionary<string, Semester> openingPeriod { get; set; }
    }
}