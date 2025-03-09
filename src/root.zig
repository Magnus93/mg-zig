//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const Node = struct {
    value: i32,
    next: ?*Node,

    fn create(allocator: std.mem.Allocator, value: i32) !*Node {
        const node = try allocator.create(Node);
        node.* = Node{ .value = value, .next = null };
        return node;
    }

    fn append(self: *Node, allocator: std.mem.Allocator, value: i32) !void {
        var current = self;
        while (current.next) |next_node| {
            current = next_node;
        }
        current.next = try create(allocator, value);
    }

    fn to_string(self: *Node) []const u8 {
        var allocator = std.heap.page_allocator;
        const buffer = try allocator.alloc(u8, 128);
        const writer = std.io.fixedBufferWriter(buffer);

        try std.fmt.format(writer, "Node{{ value: {}, next: {} }}", .{ self.value, if (self.next) "Some" else "None" });

        return buffer;
    }
    fn length(self: *Node, counter: u32) u32 {
        if (self.next) |next_node| {
            return next_node.length(counter + 1);
        } else {
            return counter + 1;
        }
    }
};

const List = struct {
    first: ?*Node,

    pub fn create(allocator: std.mem.Allocator) !*List {
        const list = try allocator.create(List);
        list.* = List{ .first = null };
        return list;
    }
    pub fn append(self: *List, allocator: std.mem.Allocator, value: i32) !void {
        if (self.first) |first_node| {
            try first_node.append(allocator, value);
        } else {
            self.first = try Node.create(allocator, value);
        }
    }
    pub fn length(self: *List) u32 {
        if (self.first) |first_node| {
            return first_node.length(0);
        } else {
            return 0;
        }
    }
};

test "list append" {
    var gpa = std.heap.page_allocator;

    const list = try List.create(gpa);
    try list.append(gpa, 2);
    try list.append(gpa, 7);
    try list.append(gpa, 9);
    try list.append(gpa, 5);

    defer gpa.destroy(list);

    try testing.expect(list.length() == 4);
}
