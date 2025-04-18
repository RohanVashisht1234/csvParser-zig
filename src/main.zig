const std = @import("std");
const csvData = @embedFile("weather.csv");

// header : []strings
// rows: [][]strings

const CSVParsingErrors = error{
    /// Occurs when Header is not implemented in a CSV
    /// which implies that the CSV file is empty.
    HeaderNotFoundEmptyCSV,
    /// If number of columns don't match the number of columns
    /// in the header.
    InvalidCSVError,
};

const csv = struct {
    number_of_columns: u16,
    number_of_rows: u32,
    header: [][]const u8,
    rows: [][][]const u8,
};

// First line of CSV:
// column_name1, column name 2
// data1, data2, data3

fn parseCSV(allocator: std.mem.Allocator, raw_data: []const u8) !csv {
    var headerList = std.ArrayList([]const u8).init(allocator);
    var iter_for_lines = std.mem.splitScalar(u8, raw_data, '\n');
    const number_of_columns = 1;
    const number_of_rows = 0;
    if (iter_for_lines.next()) |header_line| {
        var iter_for_header = std.mem.splitScalar(u8, header_line, ',');
        while (iter_for_header.next()) |column_name| {
            try headerList.append(column_name);
        }
    } else {
        return CSVParsingErrors.HeaderNotFoundEmptyCSV;
    }
    var rows = std.ArrayList([][]const u8).init(allocator);
    while (iter_for_lines.next()) |line| {
        var row = std.ArrayList([]const u8).init(allocator);
        var iter_for_header = std.mem.splitScalar(u8, line, ',');
        while (iter_for_header.next()) |data_for_inidivisual_column| {
            try row.append(data_for_inidivisual_column);
        }
        const result = try row.toOwnedSlice();
        // number_of_rows += 1;
        try rows.append(result);
    }
    const rows_result = try rows.toOwnedSlice();
    const headers_result = try headerList.toOwnedSlice();
    const main_result: csv = csv{
        .number_of_columns = number_of_columns,
        .number_of_rows = number_of_rows,
        .header = headers_result,
        .rows = rows_result,
    };
    return main_result;
}

pub fn main() !void {
    const result = try parseCSV(std.heap.c_allocator, csvData);
    for (result.rows) |header| {
        std.debug.print("{s}\n", .{header});
    }
}
