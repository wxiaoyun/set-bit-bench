const std = @import("std");

const bit_bench = @import("bit_bench");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer std.debug.assert(gpa.deinit() == .ok);

    var allocator = gpa.allocator();

    const args = std.os.argv;
    const impl = try std.fmt.parseInt(u8, std.mem.span(args[1]), 10);
    const size = std.fmt.parseInt(u64, std.mem.span(args[2]), 10) catch 1_000;

    const input = try bit_bench.randomInt(u64, allocator, size);
    defer allocator.free(input);

    var count_impl: ?*const fn (u64) u8 = null;
    switch (impl) {
        0 => count_impl = bit_bench.countSetBitNaive,
        1 => {
            bit_bench.lookupTableInit();
            count_impl = bit_bench.countSetBitLookup;
        },
        else => @panic("unexpected count implementation, options: (0) naive, (1) look up table"),
    }

    var timer = try std.time.Timer.start();
    if (count_impl) |impl_fn| {
        for (input) |n| {
            _ = impl_fn(n);
        }
    } else {
        @panic("count impl not initialised");
    }
    const t = timer.read();

    std.debug.print("Count impl: {d}\nInput size: {d}\nTime taken: {d} ns\n", .{ impl, size, t });
}
