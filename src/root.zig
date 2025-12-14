const std = @import("std");
const Allocator = std.mem.Allocator;
const Rand = std.Random;

pub fn randomInt(comptime T: type, gpa: Allocator, size: usize) ![]T {
    var prng = Rand.DefaultPrng.init(@intCast(std.time.timestamp()));
    var rand = prng.random();

    var out = try gpa.alloc(T, size);
    errdefer gpa.free(out);

    for (0..out.len) |i| {
        out[i] = rand.int(T);
    }

    return out;
}

pub fn countSetBitNaive(n: u64) u8 {
    var nset: u8 = 0;
    var num = n;

    inline for (0..64) |_| {
        nset += @intCast(num & 1);
        num >>= 1;
    }

    return nset;
}

test countSetBitNaive {
    const testing = std.testing;

    try testing.expect(countSetBitNaive(0b1) == 1);
    try testing.expect(countSetBitNaive(0b101) == 2);
    try testing.expect(countSetBitNaive(0b100010000001) == 3);
    try testing.expect(countSetBitNaive((@as(u64, 1) << 32) - 1) == 32);
}

var lookup_table: [1 << 8]u8 = undefined;

pub fn lookupTableInit() void {
    for (0..1 << 8) |i| {
        const set: u8 = @intCast(i & 1);
        lookup_table[i] = set + lookup_table[i >> 1];
    }
}

pub fn countSetBitLookup(n: u64) u8 {
    var nset: u8 = 0;
    var num = n;

    inline for (0..8) |_| {
        const sub_int: u8 = @truncate(num);
        nset += lookup_table[sub_int];
        num >>= 8;
    }

    return nset;
}

test countSetBitLookup {
    const testing = std.testing;

    lookupTableInit();
    try testing.expect(countSetBitLookup(0b1) == 1);
    try testing.expect(countSetBitLookup(0b101) == 2);
    try testing.expect(countSetBitLookup(0b100010000001) == 3);
    try testing.expect(countSetBitLookup((@as(u64, 1) << 32) - 1) == 32);
}

test "fuzz test" {
    const testing = std.testing;
    var alc = testing.allocator;
    const input = try randomInt(u64, alc, 1000000);
    defer alc.free(input);

    lookupTableInit();
    for (input) |n| {
        const left = countSetBitNaive(n);
        const right = countSetBitLookup(n);
        testing.expect(left == right) catch |e| {
            std.debug.print("n: {d}\nLEFT {d}\nRIGHT {d}\n", .{ n, left, right });
            return e;
        };
    }
}
