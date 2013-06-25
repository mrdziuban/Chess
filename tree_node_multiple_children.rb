class TreeNode
	attr_accessor :value, :parent, :children, :children_count
	# Do I need this?
	def initialize(value)
		@value = value
		@parent = nil
		@children = []
	end

	# Get node's parent
	def parent
		@parent
	end

	def children
		@children
	end

	def child=(child_node)
		child_node.parent = self
		@children << child_node
	end
end