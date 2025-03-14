const std = @import("std");

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
    header: [][]const u8,
    rows: [][][]const u8,
};

// First line of CSV:
// column_name1, column name 2
// data1, data2, data3

fn parseCSV(allocator: std.mem.Allocator, raw_data: []const u8) !csv {
    var headerList = std.ArrayList([]const u8).init(allocator);
    var iter_for_lines = std.mem.splitScalar(u8, raw_data, '\n');
    var number_of_columns = 0;
    if (iter_for_lines.next()) |header_line| {
        var iter_for_header = std.mem.splitScalar(u8, header_line, ',');
        while (iter_for_header.next()) |column_name| : (number_of_columns += 1) {
            try headerList.append(column_name);
        }
    } else {
        return CSVParsingErrors.HeaderNotFoundEmptyCSV;
    }
}

pub fn main() void {}
