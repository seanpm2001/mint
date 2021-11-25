# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := tree_sitter_mint_binding
DEFS_Debug := \
	'-DNODE_GYP_MODULE_NAME=tree_sitter_mint_binding' \
	'-DUSING_UV_SHARED=1' \
	'-DUSING_V8_SHARED=1' \
	'-DV8_DEPRECATION_WARNINGS=1' \
	'-DV8_DEPRECATION_WARNINGS' \
	'-DV8_IMMINENT_DEPRECATION_WARNINGS' \
	'-D_GLIBCXX_USE_CXX11_ABI=1' \
	'-D_LARGEFILE_SOURCE' \
	'-D_FILE_OFFSET_BITS=64' \
	'-D__STDC_FORMAT_MACROS' \
	'-DOPENSSL_NO_PINSHARED' \
	'-DOPENSSL_THREADS' \
	'-DBUILDING_NODE_EXTENSION' \
	'-DDEBUG' \
	'-D_DEBUG' \
	'-DV8_ENABLE_CHECKS'

# Flags passed to all source files.
CFLAGS_Debug := \
	-fPIC \
	-pthread \
	-Wall \
	-Wextra \
	-Wno-unused-parameter \
	-m64 \
	-g \
	-O0

# Flags passed to only C files.
CFLAGS_C_Debug := \
	-std=c99

# Flags passed to only C++ files.
CFLAGS_CC_Debug := \
	-fno-rtti \
	-fno-exceptions \
	-std=gnu++14

INCS_Debug := \
	-I/home/gdot/.cache/node-gyp/16.6.2/include/node \
	-I/home/gdot/.cache/node-gyp/16.6.2/src \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/openssl/config \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/openssl/openssl/include \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/uv/include \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/zlib \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/v8/include \
	-I$(srcdir)/node_modules/nan \
	-I$(srcdir)/src

DEFS_Release := \
	'-DNODE_GYP_MODULE_NAME=tree_sitter_mint_binding' \
	'-DUSING_UV_SHARED=1' \
	'-DUSING_V8_SHARED=1' \
	'-DV8_DEPRECATION_WARNINGS=1' \
	'-DV8_DEPRECATION_WARNINGS' \
	'-DV8_IMMINENT_DEPRECATION_WARNINGS' \
	'-D_GLIBCXX_USE_CXX11_ABI=1' \
	'-D_LARGEFILE_SOURCE' \
	'-D_FILE_OFFSET_BITS=64' \
	'-D__STDC_FORMAT_MACROS' \
	'-DOPENSSL_NO_PINSHARED' \
	'-DOPENSSL_THREADS' \
	'-DBUILDING_NODE_EXTENSION'

# Flags passed to all source files.
CFLAGS_Release := \
	-fPIC \
	-pthread \
	-Wall \
	-Wextra \
	-Wno-unused-parameter \
	-m64 \
	-O3 \
	-fno-omit-frame-pointer

# Flags passed to only C files.
CFLAGS_C_Release := \
	-std=c99

# Flags passed to only C++ files.
CFLAGS_CC_Release := \
	-fno-rtti \
	-fno-exceptions \
	-std=gnu++14

INCS_Release := \
	-I/home/gdot/.cache/node-gyp/16.6.2/include/node \
	-I/home/gdot/.cache/node-gyp/16.6.2/src \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/openssl/config \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/openssl/openssl/include \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/uv/include \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/zlib \
	-I/home/gdot/.cache/node-gyp/16.6.2/deps/v8/include \
	-I$(srcdir)/node_modules/nan \
	-I$(srcdir)/src

OBJS := \
	$(obj).target/$(TARGET)/bindings/node/binding.o \
	$(obj).target/$(TARGET)/src/parser.o

# Add to the list of files we specially track dependencies for.
all_deps += $(OBJS)

# CFLAGS et al overrides must be target-local.
# See "Target-specific Variable Values" in the GNU Make manual.
$(OBJS): TOOLSET := $(TOOLSET)
$(OBJS): GYP_CFLAGS := $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE))  $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_C_$(BUILDTYPE))
$(OBJS): GYP_CXXFLAGS := $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE))  $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_CC_$(BUILDTYPE))

# Suffix rules, putting all outputs into $(obj).

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(srcdir)/%.cc FORCE_DO_CMD
	@$(call do_cmd,cxx,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(srcdir)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

# Try building from generated source, too.

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj).$(TOOLSET)/%.cc FORCE_DO_CMD
	@$(call do_cmd,cxx,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj).$(TOOLSET)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj)/%.cc FORCE_DO_CMD
	@$(call do_cmd,cxx,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj)/%.c FORCE_DO_CMD
	@$(call do_cmd,cc,1)

# End of this set of suffix rules
### Rules for final target.
LDFLAGS_Debug := \
	-pthread \
	-rdynamic \
	-m64

LDFLAGS_Release := \
	-pthread \
	-rdynamic \
	-m64

LIBS :=

$(obj).target/tree_sitter_mint_binding.node: GYP_LDFLAGS := $(LDFLAGS_$(BUILDTYPE))
$(obj).target/tree_sitter_mint_binding.node: LIBS := $(LIBS)
$(obj).target/tree_sitter_mint_binding.node: TOOLSET := $(TOOLSET)
$(obj).target/tree_sitter_mint_binding.node: $(OBJS) FORCE_DO_CMD
	$(call do_cmd,solink_module)

all_deps += $(obj).target/tree_sitter_mint_binding.node
# Add target alias
.PHONY: tree_sitter_mint_binding
tree_sitter_mint_binding: $(builddir)/tree_sitter_mint_binding.node

# Copy this to the executable output path.
$(builddir)/tree_sitter_mint_binding.node: TOOLSET := $(TOOLSET)
$(builddir)/tree_sitter_mint_binding.node: $(obj).target/tree_sitter_mint_binding.node FORCE_DO_CMD
	$(call do_cmd,copy)

all_deps += $(builddir)/tree_sitter_mint_binding.node
# Short alias for building this executable.
.PHONY: tree_sitter_mint_binding.node
tree_sitter_mint_binding.node: $(obj).target/tree_sitter_mint_binding.node $(builddir)/tree_sitter_mint_binding.node

# Add executable to "all" target.
.PHONY: all
all: $(builddir)/tree_sitter_mint_binding.node

