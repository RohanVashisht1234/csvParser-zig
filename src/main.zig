const std = @import("std");
const libs = @import("csvLib.zig");
const csvData = @embedFile("weather.csv");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("TEST FAIL");
    }
    const result = try libs.parseCSV(allocator, csvData);
    for (result.rows) |header| {
        std.debug.print("{s}\n", .{header});
    }
    defer allocator.free(result.header);
    defer allocator.free(result.rows);
    defer for (result.rows) |row| {
        allocator.free(row);
    };
    std.debug.print("{}", .{result.number_of_columns});
}
