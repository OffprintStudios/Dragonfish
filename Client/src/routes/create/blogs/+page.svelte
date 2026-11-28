<script lang="ts">
    import type { PageProps } from "./$types";
    import { CreateNav } from "#lib/ui/nav";
    import { IconNewSection, IconSearch, IconMoodHappy, IconRating18Plus } from "@tabler/icons-svelte";
	import { resolve } from "$app/paths";
	import { localeDate, abbreviate, pluralize } from "#lib/util/functions";

    let { data }: PageProps = $props();
</script>

<CreateNav>
    {#snippet header()}
        <span class="hidden">Blogs</span>
    {/snippet}
    {#snippet tools()}
        <a
            class="cr-button primary"
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

<div class="flex flex-col max-w-4xl mx-auto py-12">
    <div class="all-small-caps border-b border-cr-header px-2 pb-2 mb-2 text-left w-full font-semibold">{abbreviate(data.blogs.metadata.total)} blog{pluralize(data.blogs.metadata.total)}</div>
    {#each data.blogs.items as blog (blog.id)}
        <a class="flex items-center my-2 px-4 h-22 w-full rounded-lg bg-cr-select hover:bg-cr-hover transition" href={resolve("/create/blogs/[id]", { id: blog.id })}>
            <span class="flex flex-col relative top-0.5">
                <h3 class="text-2xl text-cr-header!">{blog.title}</h3>
                <span class="font-header text-cr-text pt-2 text-sm">Created on {localeDate(blog.createdAt, 'longDate')}</span>
            </span>
            <span class="flex-1"></span>
            <span class="flex flex-col items-center justify-center h-full" title="Words">
                <span class="font-semibold text-xl">{abbreviate(blog.words)}</span>
                <span class="all-small-caps font-semibold text-sm relative top-0.5">word{pluralize(blog.words)}</span>
            </span>
            <span class="mx-2"></span>
            <span class="flex flex-col items-center justify-center h-full">
                <span>
                    {#if blog.nsfw}
                        <IconRating18Plus size="2rem" />
                    {:else}
                        <IconMoodHappy size="2rem" />
                    {/if}
                </span>
                <span class="all-small-caps font-semibold text-sm">
                    {#if blog.nsfw}
                        NSFW
                    {:else}
                        SFW
                    {/if}
                </span>
            </span>
        </a>
    {:else}
        <div class="empty">
            <h3 class="text-cr-header!">Nothing to see here...</h3>
            <p>Hit the Add button at the top to get started!</p>
        </div>
    {/each}
</div>