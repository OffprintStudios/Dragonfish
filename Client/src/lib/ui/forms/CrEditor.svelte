<script lang="ts">
    import DOMPurify from "dompurify";
    import TurndownService from "turndown";
    import { IconEdit, IconEye } from "@tabler/icons-svelte";
    import { md, purifyConfig } from "#lib/util/markdown";
    import { countWords, pluralize, abbreviate } from "#lib/util/functions";
	import { browser } from "$app/env";

    interface Props {
        name: string,
        placeholder?: string;
        value?: string;
        defaultPreview?: boolean;
    }

    let { name, placeholder = "All great journeys begins with a single step...", value = $bindable(""), defaultPreview = false }: Props = $props();
    // svelte-ignore state_referenced_locally
    let editMode = $state(!defaultPreview);
    let cleanedText = $derived.by(() => {
        const html = md.render(value);
        if (!browser) return '';
        return DOMPurify.sanitize(html, purifyConfig);
    });
    let wordCount = $derived.by(() => { return countWords(cleanedText ?? ""); });

    const turndown = new TurndownService({
        headingStyle: 'atx',
        codeBlockStyle: 'fenced',
        emDelimiter: '*',
        strongDelimiter: '**',
    });

    turndown.addRule('underline', {
        filter: 'u',
        replacement(content) {
            if (!content.trim()) return "";
            return `_${content}_`;
        }
    });

    function handlePaste(e: ClipboardEvent) {
        const html = e.clipboardData?.getData('text/html');
        if (!html) return; // Let normal plain-text paste happen naturally
        const cleanHTML = DOMPurify.sanitize(html, {
            FORBID_TAGS: ['style', 'script', 'meta', 'link', 'object', 'embed']
        });

        e.preventDefault();

        const el = e.currentTarget as HTMLTextAreaElement;
        const markdown = turndown.turndown(cleanHTML).trim();

        const start = el.selectionStart ?? el.value.length;
        const end = el.selectionEnd ?? el.value.length;

        el.value = el.value.slice(0, start) + markdown + el.value.slice(end);

        const nextCaret = start + markdown.length;
        queueMicrotask(() => {
            el.setSelectionRange(nextCaret, nextCaret);
        });
    }
</script>

<div class="flex flex-col w-7/12 mx-auto h-full">
    <div class="flex items-center border-y border-cr-header">
        <span class="all-small-caps font-semibold text-sm tracking-wide pl-4">{`${abbreviate(wordCount)} word${pluralize(wordCount)}`}</span>
        <div class="flex-1"></div>
        <button 
            class="flex items-center text-cr-header pl-2 pr-4 py-4 transition hover:bg-cr-hover cursor-pointer" 
            class:bg-cr-hover={editMode}
            type="button"
            onclick={() => editMode = true}
        >
            <span class="mr-0.5"><IconEdit size="1.125rem" /></span>
            <span class="text-sm font-semibold all-small-caps tracking-wide relative top-[-0.075rem]">Edit</span>
        </button>
        <button 
            class="flex items-center text-cr-header pl-2 pr-4 py-4 transition hover:bg-cr-hover cursor-pointer" 
            type="button"
            class:bg-cr-hover={!editMode}
            onclick={() => editMode = false}
        >
            <span class="mr-0.5"><IconEye size="1.125rem" /></span>
            <span class="text-sm font-semibold all-small-caps tracking-wide relative top-[-0.075rem]">Preview</span>
        </button>
    </div>
    <textarea
        id={name}
        {name}
        onpaste={handlePaste}
        {placeholder}
        rows="9"
        bind:value
        class="w-full text-cr-text pt-4 box-border resize-none field-sizing-content placeholder:text-cr-placeholder placeholder:relative placeholder:italic placeholder:top-0.5 border-0 bg-transparent focus:ring-0 focus:border-0"
        class:hidden={!editMode}
    ></textarea>
    <article
        class:hidden={editMode}
    >
        <!--eslint-disable-next-line svelte/no-at-html-tags-->
        {@html cleanedText}
    </article>
</div>
