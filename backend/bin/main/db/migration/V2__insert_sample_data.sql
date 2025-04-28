-- Insert sample categories
INSERT INTO categories (id, name, description)
VALUES 
    ('1', '전체', '모든 카테고리의 게시물'),
    ('2', '동네질문', '우리 동네에 대한 질문'),
    ('3', '동네소식', '우리 동네 뉴스와 소식'),
    ('4', '일상', '일상적인 이야기'),
    ('5', '같이해요', '함께 할 수 있는 활동'),
    ('6', '동네맛집', '동네 맛집 정보'),
    ('7', '취미생활', '취미와 관련된 이야기'),
    ('8', '분실/실종', '분실물이나 실종 관련 게시물'),
    ('9', '해주세요', '부탁이나 요청 사항');

-- Insert sample user (password is 'password' encoded with BCrypt)
INSERT INTO users (id, email, password, first_name, last_name, profile_image_url, phone, status)
VALUES (
    '1', 
    'user@example.com', 
    '$2a$10$qBq.3THL8zdQYthEgV3aD.vycqK3JvFYTOQWRUZp8GkS1/TcsgI0W', 
    'Test', 
    'User', 
    'https://randomuser.me/api/portraits/men/1.jpg', 
    '010-1234-5678', 
    'ACTIVE'
);

-- Insert sample posts
INSERT INTO posts (id, author_id, title, content, category, location, created_at, updated_at)
VALUES
    ('1', '1', '동네 맛집 추천', '새로 생긴 맛집이 있는데 정말 맛있어요! 강추합니다.', '동네맛집', '서울', DATEADD('DAY', -5, CURRENT_TIMESTAMP), DATEADD('DAY', -5, CURRENT_TIMESTAMP)),
    ('2', '1', '근처 공원에서 같이 산책하실 분?', '아침마다 근처 공원에서 산책하고 있어요. 같이 하실 분 계신가요?', '같이해요', '서울', DATEADD('DAY', -3, CURRENT_TIMESTAMP), DATEADD('DAY', -3, CURRENT_TIMESTAMP)),
    ('3', '1', '지갑을 잃어버렸어요', '어제 저녁에 동네 슈퍼마켓 근처에서 지갑을 잃어버렸어요. 혹시 보신 분 계신가요?', '분실/실종', '서울', DATEADD('DAY', -1, CURRENT_TIMESTAMP), DATEADD('DAY', -1, CURRENT_TIMESTAMP));

-- Insert sample comments
INSERT INTO comments (id, post_id, author_id, content, created_at)
VALUES
    ('1', '1', '1', '저도 가봤는데 정말 맛있더라구요! 특히 파스타가 일품이에요.', DATEADD('DAY', -4, CURRENT_TIMESTAMP)),
    ('2', '2', '1', '저도 아침 산책 좋아해요! 언제 가시나요?', DATEADD('DAY', -2, CURRENT_TIMESTAMP)),
    ('3', '3', '1', '어떤 색상의 지갑인가요? 좀 더 자세히 설명해주시면 찾는데 도움이 될 것 같아요.', DATEADD('HOUR', -12, CURRENT_TIMESTAMP));

-- Insert sample post likes
INSERT INTO post_likes (post_id, user_id)
VALUES
    ('1', '1'),
    ('2', '1');

-- Insert sample comment likes
INSERT INTO comment_likes (comment_id, user_id)
VALUES
    ('1', '1'); 