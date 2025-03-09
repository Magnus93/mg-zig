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
    fn destroy(self: *Node, allocator: std.mem.Allocator) void {
        if (self.next) |next_node| {
            next_node.destroy(allocator);
        }
        allocator.destroy(self);
    }
};

const List = struct {
    first: ?*Node,
    allocator: std.mem.Allocator,

    pub fn create(allocator: std.mem.Allocator) !*List {
        const list = try allocator.create(List);
        list.* = List{ .first = null, .allocator = allocator };
        return list;
    }
    pub fn append(self: *List, value: i32) !void {
        if (self.first) |first_node| {
            try first_node.append(self.allocator, value);
        } else {
            self.first = try Node.create(self.allocator, value);
        }
    }
    pub fn length(self: *List) u32 {
        if (self.first) |first_node| {
            return first_node.length(0);
        } else {
            return 0;
        }
    }
    pub fn destroy(self: *List) void {
        if (self.first) |first_node| {
            first_node.destroy(self.allocator);
        }
        self.allocator.destroy(self);
    }
};

test "list append" {
    const gpa = std.heap.page_allocator;

    const list = try List.create(gpa);
    try list.append(2);
    try list.append(7);
    try list.append(9);
    try list.append(5);

    defer list.destroy();

    try testing.expect(list.length() == 4);
}
