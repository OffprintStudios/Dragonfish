<script lang="ts">
    import type { Snippet } from "svelte";
    import { IconChevronLeft } from "@tabler/icons-svelte";
    import { resolve } from "$app/paths";
    import { page } from "$app/state";

    interface Props {
        showNav?: boolean,
        returnURL?: string,
        leftTools?: Snippet,
        header: Snippet,
        tools: Snippet,
    }

    let { showNav = true, returnURL = "/create", leftTools, header, tools }: Props = $props();
</script>

<div class="sticky top-0 w-full z-50 bg-cr-background border-b border-cr-header drop-shadow-xl">
    <div class="flex items-center h-13.75 mx-4 sm:mx-4 lg:mx-auto max-w-344">
        <div class="flex items-center w-1/3">
            {#if showNav}
                <a
                    class="flex items-center text-cr-header pl-1 pr-2 py-px transition rounded-lg hover:bg-cr-hover"
                    href={resolve("/(base)")}
                >
                    <span class="mr-0.5"><IconChevronLeft size="1.5rem" /></span>
                    <h3 class="flex items-center text-2xl font-bold tracking-tighter text-cr-header! relative top-0.5">Offprint</h3>
                </a>
                <span class="mx-2 relative -top-0.5 text-2xl font-extralight text-cr-header">|</span>
                <a
                    class="flex items-center text-cr-header px-4 py-2 transition rounded-lg hover:bg-cr-hover [&[aria-current=page]]:bg-cr-hover"
                    href={resolve("/create")}
                    aria-current={page.url.pathname === '/create' ? 'page' : undefined}
                >
                    <span class="text-sm font-semibold all-small-caps tracking-wide relative top-[-0.075rem]">Overview</span>
                </a>
                <span class="mx-0.5"></span>
                <a
                    class="flex items-center text-cr-header px-4 py-2 transition rounded-lg hover:bg-cr-hover [&[aria-current=page]]:bg-cr-hover"
                    href={resolve("/create/works")}
                    aria-current={page.url.pathname.startsWith("/create/works") ? 'page' : undefined}
                >
                    <span class="text-sm font-semibold all-small-caps tracking-wide relative top-[-0.075rem]">Works</span>
                </a>
                <span class="mx-0.5"></span>
                <a
                    class="flex items-center text-cr-header px-4 py-2 transition rounded-lg hover:bg-cr-hover [&[aria-current=page]]:bg-cr-hover"
                    href={resolve("/create/blogs")}
                    aria-current={page.url.pathname.startsWith("/create/blogs") ? 'page' : undefined}
                >
                    <span class="text-sm font-semibold all-small-caps tracking-wide relative top-[-0.075rem]">Blogs</span>
                </a>
            {:else}
                <!--eslint-disable-next-line svelte/no-navigation-without-resolve-->
                <a class="cr-button" href={returnURL}>
                    <span class="button-icon"><IconChevronLeft size="1rem" /></span>
                    <span class="button-text">Back</span>
                </a>
                {#if leftTools}
                    <span class="mx-2 relative -top-0.5 text-2xl font-extralight text-cr-header">|</span>
                    {@render leftTools()}
                {/if}
            {/if}
        </div>
        <div class="flex items-center justify-center w-1/3">
            {@render header()}
        </div>
        <div class="flex items-center w-1/3">
            <span class="flex-1"></span>
            {@render tools()}
        </div>
    </div>
</div>