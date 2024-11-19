import 'dart:async';
import 'package:logger/logger.dart';

abstract class Job {
  // The interval at which the job should run.
  late final Duration _interval;
  late final Timer _timer;
  late final bool _immediate;
  late final Logger log;
  late final String name;

  // Check if the job is active.
  bool isActive = false;

  Job(this._interval, this._immediate);

  // The function to run.
  void task();

  void _task() {
    log.i('Running job $name.');
    task();
  }

  // The function to run the job.
  void _run() async {
    if (_immediate) {
      _task();
    }

    _timer = Timer.periodic(_interval, (Timer timer) {
      _task();
    });

    isActive = true;
  }

  // Start the job.
  void start() {
    if (isActive) {
      return;
    }

    _run();
  }

  // Stop the job.
  void stop() {
    if (!isActive) {
      return;
    }

    _timer.cancel();
  }

  // Check if the job is running.
  bool isRunning() {
    return isActive;
  }
}

class JobScheduler {
  late final List<Job> _jobs;

  JobScheduler() {
    _jobs = [];
  }

  // Add a job to the scheduler.
  void addJob(Job job) {
    _jobs.add(job);
  }

  // Start all jobs.
  void startAll() {
    for (var job in _jobs) {
      job.start();
    }
  }

  // Stop all jobs.
  void stopAll() {
    for (var job in _jobs) {
      job.stop();
    }
  }

  // Check if all jobs are running.
  bool areAllRunning() {
    return _jobs.every((job) => job.isRunning());
  }
}
