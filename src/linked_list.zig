const std = @import("std");

const Node = struct {
    value: i32,
    next: ?*Node,
    
    pub fn create(value: i32) *Node {
        var node = Node{
            .value = value,
            .next = null,
        };
        return node;
    }

    pub fn append(self: *Node, value: i32) void {
        var current = self;
        while (current.next) |next_node| {
            current = next_node;
        }
        current.next = &Node{
            .value = Node,
        };
    }

    pub fn to_string(self: *Node) []const u8 {
        var allocator = std.heap.page_allocator;
        var buffer = try allocator.alloc(u8, 128);
        var writer = std.io.fixedBufferWriter(buffer);

        try std.fmt.format(writer, "Node{{ value: {}, next: {} }}", .{ self.value, if (self.next) |n| "Some" else "None" });
        
        return buffer;
    }
}