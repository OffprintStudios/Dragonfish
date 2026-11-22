<script lang="ts">
    import type { PageProps } from "./$types";
    import { CreateNav } from "#lib/ui/nav";
    import { IconNewSection, IconSearch } from "@tabler/icons-svelte";
	import { resolve } from "$app/paths";

    let { data }: PageProps = $props();
</script>

<CreateNav>
    {#snippet header()}
        <span class="hidden">Blogs</span>
    {/snippet}
    {#snippet tools()}
        <a
            class="cr-button"
            href={resolve("/create/blogs/new")}
        >
            <span class="button-icon"><IconNewSection size="1.125rem" /></span>
            <span class="button-text">Add</span>
        </a>
        <span class="mx-1"></span>
        <form class="flex items-center bg-cr-select rounded-xl overflow-hidden relative h-9.5">
            <input type="text" placeholder="Search..." class="bg-transparent border-0 focus:border-0 ring-0" />
            <button title="Search" class="px-4 py-3 cursor-pointer"><IconSearch size="1rem" /></button>
        </form>
    {/snippet}
</CreateNav>

<div class="max-w-7xl mx-auto">
    Has blogs: {data.blogs.items.length}
</div>