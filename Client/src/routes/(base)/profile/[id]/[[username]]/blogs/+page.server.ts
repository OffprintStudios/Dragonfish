import { BASE_URL } from "#lib/http";
import type { Blog } from "#lib/models/blogs";
import type { Paginate } from "#lib/models/util/tools";
import { error } from "@sveltejs/kit";
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ params, fetch }) => {
    const id = params.id;

    const apiResponse = await fetch(`${BASE_URL}/profiles/${id}/blogs`, { method: "GET" });
    
    if (apiResponse.ok) {
        return { blogs: (await apiResponse.json()) as Paginate<Blog> };
    }

    throw error(apiResponse.status, apiResponse.statusText);
}