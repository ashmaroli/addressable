# frozen_string_literal: true

namespace :profile do
  desc "Profile memory allocations"
  task :memory do
    require "memory_profiler"
    require "addressable/uri"
    if ENV["IDNA_MODE"] == "pure"
      Addressable.send(:remove_const, :IDNA)
      load "addressable/idna/pure.rb"
    end

    report = MemoryProfiler.report do
      30000.times do
        u = Addressable::URI.parse('http://google.com/stuff/../?with_lots=of&params=asdff#!stuff')
        u.normalize
      end
    end

    puts ""
    puts "-" * 80
    puts ""

    if ENV["CI"]
      report.pretty_print(scale_bytes: true, color_output: false, normalize_paths: true)
    else
      FileUtils.mkdir_p("tmp")
      report_file = "tmp/memprof.txt"

      total_allocated_output = report.scale_bytes(report.total_allocated_memsize)
      total_retained_output  = report.scale_bytes(report.total_retained_memsize)

      puts "Total allocated: #{total_allocated_output} (#{report.total_allocated} objects)"
      puts "Total retained:  #{total_retained_output} (#{report.total_retained} objects)"

      report.pretty_print(to_file: report_file, scale_bytes: true, normalize_paths: true)
    end
  end
end
