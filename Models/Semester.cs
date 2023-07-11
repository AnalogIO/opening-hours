using System;
using System.Collections.Generic;

namespace Models
{
    public class Semester
    {
        public DateTime firstDate { get; set; }
        public DateTime closingDate { get; set; }
        public List<DateTime> closedDates { get; set; }
    }
}