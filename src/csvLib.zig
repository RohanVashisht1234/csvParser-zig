const std = @import("std");

pub const CSVParsingErrors = error{
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

pub fn parseCSV(allocator: std.mem.Allocator, raw_data: []const u8) !csv {
    var headerList = std.ArrayList([]const u8).init(allocator);
    errdefer headerList.deinit();
    var iter_for_lines = std.mem.splitScalar(u8, raw_data, '\n');
    var number_of_columns: u16 = 0;
    var number_of_rows: u32 = 1;
    if (iter_for_lines.next()) |header_line| {
        var iter_for_header = std.mem.splitScalar(u8, header_line, ',');
        while (iter_for_header.next()) |column_name| {
            try headerList.append(column_name);
            number_of_columns += 1;
        }
    } else {
        return CSVParsingErrors.HeaderNotFoundEmptyCSV;
    }
    var rows = std.ArrayList([][]const u8).init(allocator);
    errdefer rows.deinit();
    while (iter_for_lines.next()) |line| {
        if (std.mem.eql(u8, line, " ") or std.mem.eql(u8, line, "\n") or std.mem.eql(u8, line, "")) {
            continue;
        }
        var row = std.ArrayList([]const u8).init(allocator);
        var iter_for_header = std.mem.splitScalar(u8, line, ',');
        var column_count: u16 = 0;
        while (iter_for_header.next()) |data_for_inidivisual_column| : (column_count += 1) {
            try row.append(data_for_inidivisual_column);
        }
        if (column_count != number_of_columns) {
            std.debug.print("{}:{}:{}", .{ column_count, number_of_columns, number_of_rows });
            return CSVParsingErrors.InvalidCSVError;
        }
        const result = try row.toOwnedSlice();
        number_of_rows += 1;
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
