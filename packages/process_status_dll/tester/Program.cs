using process_status_dll;
using System;

namespace tester
{
    class Program
    {
        static void Main(string[] args)
        {
            var check = Processes.check();
            Console.WriteLine(check);
        }
    }
}
