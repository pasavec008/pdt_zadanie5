COPY(
	SELECT json_build_object(
		'id', c.id,
		'content', c.content,
		'possibly_sensitive', c.possibly_sensitive,
		'language', c.language,
		'source', c.source,
		'retweet_count', c.retweet_count,
		'reply_count', c.reply_count,
		'like_count', c.like_count,
		'quote_count', c.quote_count,
		'created_at', c.created_at,
		'author.id', author.id,
		'author.name', author.name,
		'author.username', author.username,
		'author.description', author.description,
		'author.followers_count', author.followers_count,
		'author.following_count', author.following_count,
		'author.tweet_count', author.tweet_count,
		'author.listed_count', author.listed_count,
		'hashtags', h_l,
		'links', l_l,
		'annotations', a_l,
		'context_domains', cd_l ,
		'context_entities', ce_l,
		'conversation_references', cr_l
	)
	FROM conversations c
	JOIN authors author ON author.id = c.author_id
	LEFT JOIN LATERAL(
		SELECT COALESCE(json_agg(json_build_object('id', h.id, 'tag', h.tag)), '[]'::json) h_l
		FROM hashtags h
		JOIN conversation_hashtags ch ON ch.hashtag_id = h.id AND ch.conversation_id = c.id
	) AS h_l ON true
	LEFT JOIN LATERAL(
		SELECT COALESCE(json_agg(json_build_object('id', l.id, 'url', l.url, 'title', l.title, 'description', l.description)), '[]'::json) l_l
		FROM links l
		WHERE l.conversation_id = c.id
	) AS l_l ON true
	LEFT JOIN LATERAL(
		SELECT COALESCE(json_agg(json_build_object('id', a.id, 'value', a.value, 'type', a.type, 'probability', a.probability)), '[]'::json) a_l
		FROM annotations a
		WHERE a.conversation_id = c.id
	) AS a_l ON true
	LEFT JOIN LATERAL(
		SELECT COALESCE(json_agg(json_build_object('id', cd.id, 'name', cd.name, 'description', cd.description)), '[]'::json) cd_l
		FROM context_domains cd
		JOIN context_annotations ca ON ca.context_domain_id = cd.id AND ca.conversation_id = c.id
	) AS cd_l ON true
	LEFT JOIN LATERAL(
		SELECT COALESCE(json_agg(json_build_object('id', ce.id, 'name', ce.name, 'description', ce.description)), '[]'::json) ce_l
		FROM context_entities ce
		JOIN context_annotations ca ON ca.context_domain_id = ce.id AND ca.conversation_id = c.id
	) AS ce_l ON true
	LEFT JOIN LATERAL(
		SELECT COALESCE(json_agg(json_build_object(
			'id', cr.id,
			'type', cr.type,
			'parent_conversation.author.id', author2.id,
			'parent_conversation.author.name', author2.name,
			'parent_conversation.author.username', author2.username,
			'parent_conversation.content', c2.content,
			'parent_conversation.hashtags', (
				SELECT json_agg(json_build_object('id', h.id, 'tag', h.tag))
				FROM conversation_hashtags ch
				JOIN hashtags h ON ch.hashtag_id = h.id
				WHERE ch.conversation_id = c2.id
			))
		), '[]'::json) cr_l
		FROM conversation_references cr
		JOIN conversations c2 ON c2.id = cr.parent_id
		JOIN authors author2 ON author2.id = c2.author_id
		WHERE cr.conversation_id = c.id
	) AS cr_l ON true
	--WHERE c.id = 851268950419587074
	LIMIT 500
) TO 'D:\skola2022_2023\PDT\zadanie5\file.json' WITH (FORMAT CSV, QUOTE ' ');

-- create indexes for foreign keys --
-- CREATE INDEX conversations_index ON conversations USING btree(author_id);
-- CREATE INDEX hashtag_index_1 ON conversation_hashtags USING btree(conversation_id);
-- CREATE INDEX hashtag_index_2 ON conversation_hashtags USING btree(hashtag_id);
-- CREATE INDEX link_index ON links USING btree(conversation_id);
-- CREATE INDEX annotations_index ON annotations USING btree(conversation_id);
-- CREATE INDEX context_annotations_index_1 ON context_annotations USING btree(conversation_id);
-- CREATE INDEX context_annotations_index_2 ON context_annotations USING btree(context_domain_id);
-- CREATE INDEX context_annotations_index_3 ON context_annotations USING btree(context_entity_id);
-- CREATE INDEX conversation_references_index_1 ON conversation_references USING btree(conversation_id);
-- CREATE INDEX conversation_references_index_2 ON conversation_references USING btree(parent_id);