# abcbenchmarking
ABC Benchmarking System

The ABC benchmarking system is intended to run benchmark instances with multiple system configurations
and extract benchmark parameters (such as grounding and solving time, number of answer sets) for each.
It supports automated scheduling of instances, parameter extraction,
aggregating the parameters, generating a table in text or Latex format,
and comparison of the results with previous runs.
For scheduling benchmark instances, the system supports sequential runs using shell scripts only,
or the HTCondor system (http://research.cs.wisc.edu/htcondor).

For details see abcmanual/abcmanual.pdf.
